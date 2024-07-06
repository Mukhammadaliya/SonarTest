package uz.greenwhite.biruni;

import org.json.JSONObject;
import scala.io.Codec;
import scala.io.Source;
import uz.greenwhite.biruni.http.TrustAllCerts;

import javax.net.ssl.HttpsURLConnection;

import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;

public class ExternalServiceProvider {
    public static void request(String requestData, HttpServletResponse response) throws IOException {
        JSONObject obj = new JSONObject(requestData);
        HttpURLConnection conn = null;

        try {
            TrustAllCerts trustAllCerts = new TrustAllCerts();
            trustAllCerts.trust();

            URL url = URI.create(obj.getString("url")).toURL();

            String protocol = url.getProtocol().toLowerCase();
            if ("http".equals(protocol)) conn = (HttpURLConnection) url.openConnection();
            else if ("https".equals(protocol)) conn = (HttpsURLConnection) url.openConnection();

            assert conn != null;
            conn.setUseCaches(false);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; utf-8");
            conn.setDoOutput(true);

            if (obj.has("auth_type") && obj.has("auth_token"))
                conn.setRequestProperty("Authorization", obj.getString("auth_type") + " " + obj.getString("auth_token"));

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = obj.getString("request_data").getBytes(Codec.UTF8().name());
                os.write(input, 0, input.length);
            }

            if (conn.getResponseCode() != 200)
                throw new RuntimeException(Source.fromInputStream(conn.getErrorStream(), Codec.UTF8()).mkString());

            response.getWriter().write(Source.fromInputStream(conn.getInputStream(), Codec.UTF8()).mkString());
        } catch (Exception ex) {
            throw new RuntimeException("Error occurred while connecting external server " + ex.getMessage());
        } finally {
            if (conn != null) conn.disconnect();
        }
    }
}
