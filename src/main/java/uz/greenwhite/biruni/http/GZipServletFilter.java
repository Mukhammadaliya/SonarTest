package uz.greenwhite.biruni.http;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class GZipServletFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void destroy() {
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpServletRequest req = (HttpServletRequest) request;
        String uri = req.getRequestURI().substring(req.getContextPath().length());

        if (uri.equals("/a2") || uri.equals("/a2/") || (uri.startsWith("/a2") && Files.notExists(Path.of(httpRequest.getServletContext().getRealPath("/"), uri)))) {
            request.getRequestDispatcher("/a2/login.html").forward(request, response);
            return;
        }

        if (uri.startsWith("/b/") || uri.contains(".json") || uri.contains(".html") || "/".equals(uri)) {
            httpResponse.addHeader("Cache-Control", "no-cache");
        }

        if (acceptsGZipEncoding(httpRequest)) {
            httpResponse.addHeader("Content-Encoding", "gzip");
            GZipServletResponseWrapper gzipResponse = new GZipServletResponseWrapper(httpResponse);
            chain.doFilter(request, gzipResponse);
            gzipResponse.close();
        } else {
            chain.doFilter(request, response);
        }
    }

    private boolean acceptsGZipEncoding(HttpServletRequest httpRequest) {
        String acceptEncoding = httpRequest.getHeader("Accept-Encoding");
        return acceptEncoding != null && acceptEncoding.contains("gzip");
    }
}