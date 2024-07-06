package uz.greenwhite.biruni.test;

import com.google.common.escape.Escaper;
import com.google.common.html.HtmlEscapers;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.greenwhite.biruni.util.ServletUtil;

import java.io.IOException;

public class TestServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long currentTime = System.currentTimeMillis();
        String input = ServletUtil.getRequestInput(req);
        System.out.println("Time to read data: " + (System.currentTimeMillis() - currentTime));

        currentTime = System.currentTimeMillis();
        Escaper htmlEscaper = HtmlEscapers.htmlEscaper();
        System.out.println("Time to create escaper: " + (System.currentTimeMillis() - currentTime));

        currentTime = System.currentTimeMillis();
        String output = htmlEscaper.escape(input);
        System.out.println("Time to escape data: " + (System.currentTimeMillis() - currentTime));

        currentTime = System.currentTimeMillis();
        resp.getWriter().write(output);
        System.out.println("Time to write data: " + (System.currentTimeMillis() - currentTime));
    }
}
