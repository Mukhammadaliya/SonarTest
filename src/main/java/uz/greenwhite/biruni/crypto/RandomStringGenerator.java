package uz.greenwhite.biruni.crypto;

import java.security.SecureRandom;

public class RandomStringGenerator {
    private static final String source = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";
    private static final int size = source.length();

    public static String generate(int len){
        SecureRandom random = new SecureRandom();
        char[] result = new char[len];

        for (int i = 0; i < len; i ++) {
            result[i] = source.charAt(random.nextInt(size));
        }

        return new String(result);
    }
}
