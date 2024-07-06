package uz.greenwhite.biruni.servlet;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.greenwhite.biruni.filemanager.FileManager;
import uz.greenwhite.biruni.property.ApplicationProperty;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;

public class DocsLoadServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) {
        // validation
        String authorizationHeader = req.getHeader("authorizationjwt");
        // Check if Authorization header is present
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        // Extract JWT token
        String jwtToken = authorizationHeader.substring(7);
        // Check if JWT token is valid
        DecodedJWT decodedJWT = verifyToken(jwtToken);
        if (decodedJWT == null) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        // Parsing JWT Payload Claims
        try {
            // Get JWT claim URL
            String claimUrl = decodedJWT.getClaim("payload").asMap().get("url").toString();
            URI claimUrlObject = new URI(claimUrl);
            // Redirect if the Claim URL is different
            if (!claimUrlObject.getPath().equals(req.getContextPath() + req.getServletPath())) {
                res.sendRedirect(claimUrl);
                return;
            }
            String claimQuery = claimUrlObject.getQuery();
            // Check if query is present
            if (claimQuery == null) {
                res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            // Get JWT Claim URL query params
            String claimSha = getQueryParams(claimQuery).get("sha");
            // Check if JWT Claim sha is present
            if (claimSha == null) {
                res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            // serving document
            byte[] fileBytes = FileManager.loadFile(claimSha);
            res.setContentType("application/octet-stream");
            res.setContentLength(fileBytes.length);
            res.getOutputStream().write(fileBytes);
        } catch (URISyntaxException | IOException e) {
            throw new RuntimeException(e);
        }
    }

    private Map<String, String> getQueryParams(String claimQuery) {
        String[] claimQueryPairs = claimQuery.split("&");
        Map<String, String> claimQueryParams = new HashMap<>();
        for (String pair : claimQueryPairs) {
            int idx = pair.indexOf("=");
            String key = idx > 0 ? pair.substring(0, idx) : pair;
            String value = idx > 0 && pair.length() > idx + 1 ? pair.substring(idx + 1) : null;
            claimQueryParams.put(key, value);
        }
        return claimQueryParams;
    }

    private DecodedJWT verifyToken(String token) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(ApplicationProperty.getOnlyofficeSecret());
            JWTVerifier verifier = JWT.require(algorithm)
                    .ignoreIssuedAt()
                    .build();
            return verifier.verify(token); // Token verification succeeded
        } catch (Exception e) {
            // Invalid signature or claims
            return null; // Token verification failed
        }
    }
}
