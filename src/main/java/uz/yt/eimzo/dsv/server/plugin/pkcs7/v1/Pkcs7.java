package uz.yt.eimzo.dsv.server.plugin.pkcs7.v1;

import jakarta.jws.WebMethod;
import jakarta.jws.WebParam;
import jakarta.jws.WebResult;
import jakarta.jws.WebService;
import jakarta.xml.bind.annotation.XmlSeeAlso;
import jakarta.xml.ws.Action;
import jakarta.xml.ws.RequestWrapper;
import jakarta.xml.ws.ResponseWrapper;

@WebService(name = "Pkcs7", targetNamespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/")
@XmlSeeAlso({ObjectFactory.class})
public interface Pkcs7 {
    @WebMethod
    @WebResult(targetNamespace = "")
    @RequestWrapper(
            localName = "verifyPkcs7Detached",
            targetNamespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            className = "uz.yt.eimzo.dsv.server.plugin.pkcs7.v1.VerifyPkcs7Detached"
    )
    @ResponseWrapper(
            localName = "verifyPkcs7DetachedResponse",
            targetNamespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            className = "uz.yt.eimzo.dsv.server.plugin.pkcs7.v1.VerifyPkcs7DetachedResponse"
    )
    @Action(
            input = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/Pkcs7/verifyPkcs7DetachedRequest",
            output = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/Pkcs7/verifyPkcs7DetachedResponse"
    )
    String verifyPkcs7Detached(@WebParam(name = "dataB64", targetNamespace = "") String var1, @WebParam(name = "pkcs7B64", targetNamespace = "") String var2);

    @WebMethod
    @WebResult(targetNamespace = "")
    @RequestWrapper(
            localName = "verifyPkcs7",
            targetNamespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            className = "uz.yt.eimzo.dsv.server.plugin.pkcs7.v1.VerifyPkcs7"
    )
    @ResponseWrapper(
            localName = "verifyPkcs7Response",
            targetNamespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            className = "uz.yt.eimzo.dsv.server.plugin.pkcs7.v1.VerifyPkcs7Response"
    )
    @Action(
            input = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/Pkcs7/verifyPkcs7Request",
            output = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/Pkcs7/verifyPkcs7Response"
    )
    String verifyPkcs7(@WebParam(name = "pkcs7B64", targetNamespace = "") String var1);

    @WebMethod
    @WebResult(targetNamespace = "")
    @RequestWrapper(
            localName = "createPkcs7",
            targetNamespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            className = "uz.yt.eimzo.dsv.server.plugin.pkcs7.v1.CreatePkcs7"
    )
    @ResponseWrapper(
            localName = "createPkcs7Response",
            targetNamespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            className = "uz.yt.eimzo.dsv.server.plugin.pkcs7.v1.CreatePkcs7Response"
    )
    @Action(
            input = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/Pkcs7/createPkcs7Request",
            output = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/Pkcs7/createPkcs7Response"
    )
    String createPkcs7(@WebParam(name = "document", targetNamespace = "") byte[] var1, @WebParam(name = "apikey", targetNamespace = "") String var2);
}