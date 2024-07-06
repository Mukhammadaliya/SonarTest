package uz.greenwhite.biruni.crypto;

import javax.crypto.Cipher;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

public class DigitalSignatureRSA {
    private static final String HASH_ALGORITHM = "SHA-256";

    public static String hex(byte[] bytes) {
        StringBuilder r = new StringBuilder();

        for (byte aByte : bytes) {
            r.append(Integer.toString((aByte & 0xff) + 0x100, 16).substring(1));
        }

        return r.toString();
    }

    public static String hash(String text) throws Exception {
        MessageDigest md = MessageDigest.getInstance(HASH_ALGORITHM);

        md.update(text.getBytes(StandardCharsets.UTF_8));

        return hex(md.digest());
    }

    public static KeyPair generateKeyPair(int keySize) throws Exception {
        KeyPairGenerator kpg = KeyPairGenerator.getInstance("RSA");
        kpg.initialize(keySize);

        return kpg.generateKeyPair();
    }

    public static String encodePrivateKey(PrivateKey key) {
        return Base64.getEncoder().encodeToString(key.getEncoded());
    }

    public static PublicKey decodePublicKey(String key64) throws Exception {
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(Base64.getDecoder().decode(key64));
        KeyFactory fact = KeyFactory.getInstance("RSA");

        return fact.generatePublic(keySpec);
    }

    public static String encrypt(String plainText, String publicKey) throws Exception {
        Cipher encryptCipher = Cipher.getInstance("RSA");
        encryptCipher.init(Cipher.ENCRYPT_MODE, decodePublicKey(publicKey));

        return new String(Base64.getEncoder().encode(encryptCipher.doFinal(plainText.getBytes())), StandardCharsets.UTF_8);
    }

    public static String encodePublicKey(PublicKey key) {
        return Base64.getEncoder().encodeToString(key.getEncoded());
    }

    public static PrivateKey decodePrivateKey(String key64) throws Exception {
        PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(Base64.getDecoder().decode(key64));
        KeyFactory fact = KeyFactory.getInstance("RSA");

        return fact.generatePrivate(keySpec);
    }

    public static String decrypt(String encryptedText, String privateKey) throws Exception {
        Cipher decryptCipher = Cipher.getInstance("RSA");
        decryptCipher.init(Cipher.DECRYPT_MODE, decodePrivateKey(privateKey));

        return new String(decryptCipher.doFinal(Base64.getDecoder().decode(encryptedText)), StandardCharsets.UTF_8);
    }
}
