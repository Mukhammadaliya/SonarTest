package uz.yt.eimzo.dsv.server.plugin.pkcs7.v1;

import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;
import javax.xml.namespace.QName;

import jakarta.xml.ws.Service;
import jakarta.xml.ws.WebEndpoint;
import jakarta.xml.ws.WebServiceClient;
import jakarta.xml.ws.WebServiceException;
import jakarta.xml.ws.WebServiceFeature;

@WebServiceClient(
        name = "Pkcs7Service",
        targetNamespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
        wsdlLocation = "http://127.0.0.1:9090/dsvs/pkcs7/v1?wsdl"
)
public class Pkcs7Service extends Service {
    private static final URL PKCS7SERVICE_WSDL_LOCATION;
    private static final WebServiceException PKCS7SERVICE_EXCEPTION;
    private static final QName PKCS7SERVICE_QNAME = new QName("http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/", "Pkcs7Service");

    public Pkcs7Service() {
        super(__getWsdlLocation(), PKCS7SERVICE_QNAME);
    }

    public Pkcs7Service(WebServiceFeature... var1) {
        super(__getWsdlLocation(), PKCS7SERVICE_QNAME, var1);
    }

    public Pkcs7Service(URL var1) {
        super(var1, PKCS7SERVICE_QNAME);
    }

    public Pkcs7Service(URL var1, WebServiceFeature... var2) {
        super(var1, PKCS7SERVICE_QNAME, var2);
    }

    public Pkcs7Service(URL var1, QName var2) {
        super(var1, var2);
    }

    public Pkcs7Service(URL var1, QName var2, WebServiceFeature... var3) {
        super(var1, var2, var3);
    }

    @WebEndpoint(
            name = "Pkcs7Port"
    )
    public Pkcs7 getPkcs7Port() {
        return super.getPort(new QName("http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/", "Pkcs7Port"), Pkcs7.class);
    }

    @WebEndpoint(
            name = "Pkcs7Port"
    )
    public Pkcs7 getPkcs7Port(WebServiceFeature... var1) {
        return (Pkcs7) super.getPort(new QName("http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/", "Pkcs7Port"), Pkcs7.class, var1);
    }

    private static URL __getWsdlLocation() {
        if (PKCS7SERVICE_EXCEPTION != null) {
            throw PKCS7SERVICE_EXCEPTION;
        } else {
            return PKCS7SERVICE_WSDL_LOCATION;
        }
    }

    static {
        URL var0 = null;
        WebServiceException var1 = null;

        try {
            var0 = URI.create("http://127.0.0.1:9090/dsvs/pkcs7/v1?wsdl").toURL();
        } catch (MalformedURLException var3) {
            var1 = new WebServiceException(var3);
        }

        PKCS7SERVICE_WSDL_LOCATION = var0;
        PKCS7SERVICE_EXCEPTION = var1;
    }
}