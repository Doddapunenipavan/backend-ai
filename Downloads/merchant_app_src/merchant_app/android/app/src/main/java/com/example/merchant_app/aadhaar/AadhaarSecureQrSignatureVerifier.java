package com.example.merchant_app.aadhaar;

import android.content.Context;
import android.content.res.AssetManager;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.PublicKey;
import java.security.Signature;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Offline UIDAI Secure QR signature verify (Java Security APIs).
 * Never skipped — callers must reject when isValid == false.
 */
public final class AadhaarSecureQrSignatureVerifier {

    public static final int SIGNATURE_LENGTH = 256;
    public static final String ALGORITHM = "SHA256withRSA";

    private static final String[] PREFERRED_CERTS = {
            "uidai_offline_publickey_2026.cer",
            "uidai_auth_sign_Prod_2026.cer",
            "uidai_offline_publickey_17022026.cer",
            "uidai_auth_prod.cer",
            "uidai_auth_prod_2028.cer",
            "uidai_auth_sign_prod_2023.cer",
            "uidai_auth_sign_prod.cer",
            "uidai_12_06_18_cer.cer",
    };

    private final Context appContext;
    private List<CertEntry> cachedCerts;

    public AadhaarSecureQrSignatureVerifier(Context context) {
        this.appContext = context.getApplicationContext();
    }

    public Map<String, Object> verifyRawPayload(String rawPayload) {
        if (rawPayload == null || rawPayload.trim().isEmpty()) {
            throw new IllegalArgumentException("Empty QR payload — rejected");
        }
        byte[] rawBytes = payloadToBytes(rawPayload.trim());
        if (rawBytes.length <= SIGNATURE_LENGTH + 8) {
            Map<String, Object> reject = new LinkedHashMap<>();
            reject.put("isValid", false);
            reject.put("rejected", true);
            reject.put("algorithm", ALGORITHM);
            reject.put("signatureLength", 0);
            reject.put("signedDataLength", rawBytes.length);
            reject.put("certificateUsed", null);
            reject.put("triedCertificates", new ArrayList<String>());
            reject.put("message",
                    "QR REJECTED — payload too short for RSA-2048 signature");
            return reject;
        }
        byte[] signedData = new byte[rawBytes.length - SIGNATURE_LENGTH];
        byte[] signature = new byte[SIGNATURE_LENGTH];
        System.arraycopy(rawBytes, 0, signedData, 0, signedData.length);
        System.arraycopy(rawBytes, signedData.length, signature, 0, SIGNATURE_LENGTH);
        return verify(signedData, signature);
    }

    public Map<String, Object> verify(byte[] signedData, byte[] signature) {
        if (signedData == null || signedData.length == 0) {
            throw new IllegalArgumentException("signedData is empty");
        }
        if (signature == null || signature.length == 0) {
            throw new IllegalArgumentException("signature is empty");
        }

        List<CertEntry> certs = loadCertificates();
        List<String> tried = new ArrayList<>();
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("algorithm", ALGORITHM);
        result.put("signatureLength", signature.length);
        result.put("signedDataLength", signedData.length);

        if (certs.isEmpty()) {
            result.put("isValid", false);
            result.put("rejected", true);
            result.put("message", "No UIDAI .cer in assets/uidai_certs");
            result.put("triedCertificates", tried);
            result.put("certificateUsed", null);
            return result;
        }

        for (CertEntry entry : certs) {
            tried.add(entry.label);
            try {
                Signature sig = Signature.getInstance(ALGORITHM);
                sig.initVerify(entry.publicKey);
                sig.update(signedData);
                if (sig.verify(signature)) {
                    result.put("isValid", true);
                    result.put("rejected", false);
                    result.put("certificateUsed", entry.label);
                    result.put("message",
                            "Digital signature VALID (SHA256withRSA, cert="
                                    + entry.label + ")");
                    result.put("triedCertificates", tried);
                    return result;
                }
            } catch (Exception e) {
                tried.add(entry.label + ":error");
            }
        }

        result.put("isValid", false);
        result.put("rejected", true);
        result.put("certificateUsed", null);
        result.put("message",
                "Digital signature INVALID — QR rejected (UIDAI certs tried)");
        result.put("triedCertificates", tried);
        return result;
    }

    static byte[] payloadToBytes(String payload) {
        String cleaned = payload.trim();
        if (cleaned.matches("^\\d+$")) {
            BigInteger bi = new BigInteger(cleaned);
            byte[] bytes = bi.toByteArray();
            if (bytes.length > 1 && bytes[0] == 0x00) {
                byte[] unsigned = new byte[bytes.length - 1];
                System.arraycopy(bytes, 1, unsigned, 0, unsigned.length);
                return unsigned;
            }
            return bytes;
        }
        String hex = cleaned.replaceAll("\\s+", "");
        if (hex.matches("(?i)^[0-9a-f]+$") && hex.length() % 2 == 0) {
            return hexToBytes(hex);
        }
        try {
            String b64 = cleaned.replace('-', '+').replace('_', '/');
            int pad = (4 - (b64.length() % 4)) % 4;
            for (int i = 0; i < pad; i++) b64 += "=";
            return android.util.Base64.decode(b64, android.util.Base64.DEFAULT);
        } catch (Exception ignored) {
        }
        return cleaned.getBytes(StandardCharsets.ISO_8859_1);
    }

    private static byte[] hexToBytes(String hex) {
        int len = hex.length();
        byte[] out = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            out[i / 2] = (byte) Integer.parseInt(hex.substring(i, i + 2), 16);
        }
        return out;
    }

    private synchronized List<CertEntry> loadCertificates() {
        if (cachedCerts != null) return cachedCerts;
        List<CertEntry> list = new ArrayList<>();
        AssetManager am = appContext.getAssets();
        String base = "uidai_certs";
        for (String name : PREFERRED_CERTS) {
            CertEntry e = loadCer(am, base + "/" + name, name);
            if (e != null) list.add(e);
        }
        try {
            String[] files = am.list(base);
            if (files != null) {
                for (String name : files) {
                    if (!name.toLowerCase(Locale.US).endsWith(".cer")) continue;
                    boolean already = false;
                    for (CertEntry e : list) {
                        if (e.label.equals(name)) {
                            already = true;
                            break;
                        }
                    }
                    if (already) continue;
                    CertEntry e = loadCer(am, base + "/" + name, name);
                    if (e != null) list.add(e);
                }
            }
        } catch (IOException ignored) {
        }
        cachedCerts = list;
        return list;
    }

    private static CertEntry loadCer(AssetManager am, String assetPath, String label) {
        try (InputStream in = am.open(assetPath)) {
            byte[] der = readAll(in);
            CertificateFactory cf = CertificateFactory.getInstance("X.509");
            X509Certificate cert =
                    (X509Certificate) cf.generateCertificate(new ByteArrayInputStream(der));
            return new CertEntry(label, cert.getPublicKey());
        } catch (Exception e) {
            return null;
        }
    }

    private static byte[] readAll(InputStream in) throws IOException {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        byte[] buf = new byte[4096];
        int n;
        while ((n = in.read(buf)) != -1) bos.write(buf, 0, n);
        return bos.toByteArray();
    }

    private static final class CertEntry {
        final String label;
        final PublicKey publicKey;

        CertEntry(String label, PublicKey publicKey) {
            this.label = label;
            this.publicKey = publicKey;
        }
    }
}
