package uz.yt.eimzo.dsv.server.plugin.pkcs7.v1;

import jakarta.xml.bind.JAXBElement;
import jakarta.xml.bind.annotation.XmlElementDecl;
import jakarta.xml.bind.annotation.XmlRegistry;

import javax.xml.namespace.QName;

@XmlRegistry
public class ObjectFactory {
    private static final QName _VerifyPkcs7Response_QNAME = new QName("http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/", "verifyPkcs7Response");
    private static final QName _VerifyPkcs7Detached_QNAME = new QName("http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/", "verifyPkcs7Detached");
    private static final QName _CreatePkcs7Response_QNAME = new QName("http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/", "createPkcs7Response");
    private static final QName _VerifyPkcs7_QNAME = new QName("http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/", "verifyPkcs7");
    private static final QName _VerifyPkcs7DetachedResponse_QNAME = new QName("http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/", "verifyPkcs7DetachedResponse");
    private static final QName _CreatePkcs7_QNAME = new QName("http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/", "createPkcs7");
    private static final QName _CreatePkcs7Document_QNAME = new QName("", "document");

    public ObjectFactory() {
    }

    public VerifyPkcs7Response createVerifyPkcs7Response() {
        return new VerifyPkcs7Response();
    }

    public CreatePkcs7Response createCreatePkcs7Response() {
        return new CreatePkcs7Response();
    }

    public VerifyPkcs7Detached createVerifyPkcs7Detached() {
        return new VerifyPkcs7Detached();
    }

    public VerifyPkcs7DetachedResponse createVerifyPkcs7DetachedResponse() {
        return new VerifyPkcs7DetachedResponse();
    }

    public VerifyPkcs7 createVerifyPkcs7() {
        return new VerifyPkcs7();
    }

    public CreatePkcs7 createCreatePkcs7() {
        return new CreatePkcs7();
    }

    @XmlElementDecl(
            namespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            name = "verifyPkcs7Response"
    )
    public JAXBElement<VerifyPkcs7Response> createVerifyPkcs7Response(VerifyPkcs7Response var1) {
        return new JAXBElement(_VerifyPkcs7Response_QNAME, VerifyPkcs7Response.class, (Class) null, var1);
    }

    @XmlElementDecl(
            namespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            name = "verifyPkcs7Detached"
    )
    public JAXBElement<VerifyPkcs7Detached> createVerifyPkcs7Detached(VerifyPkcs7Detached var1) {
        return new JAXBElement(_VerifyPkcs7Detached_QNAME, VerifyPkcs7Detached.class, (Class) null, var1);
    }

    @XmlElementDecl(
            namespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            name = "createPkcs7Response"
    )
    public JAXBElement<CreatePkcs7Response> createCreatePkcs7Response(CreatePkcs7Response var1) {
        return new JAXBElement(_CreatePkcs7Response_QNAME, CreatePkcs7Response.class, (Class) null, var1);
    }

    @XmlElementDecl(
            namespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            name = "verifyPkcs7"
    )
    public JAXBElement<VerifyPkcs7> createVerifyPkcs7(VerifyPkcs7 var1) {
        return new JAXBElement(_VerifyPkcs7_QNAME, VerifyPkcs7.class, (Class) null, var1);
    }

    @XmlElementDecl(
            namespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            name = "verifyPkcs7DetachedResponse"
    )
    public JAXBElement<VerifyPkcs7DetachedResponse> createVerifyPkcs7DetachedResponse(VerifyPkcs7DetachedResponse var1) {
        return new JAXBElement(_VerifyPkcs7DetachedResponse_QNAME, VerifyPkcs7DetachedResponse.class, (Class) null, var1);
    }

    @XmlElementDecl(
            namespace = "http://v1.pkcs7.plugin.server.dsv.eimzo.yt.uz/",
            name = "createPkcs7"
    )
    public JAXBElement<CreatePkcs7> createCreatePkcs7(CreatePkcs7 var1) {
        return new JAXBElement(_CreatePkcs7_QNAME, CreatePkcs7.class, (Class) null, var1);
    }

    @XmlElementDecl(
            namespace = "",
            name = "document",
            scope = CreatePkcs7.class
    )
    public JAXBElement<byte[]> createCreatePkcs7Document(byte[] var1) {
        return new JAXBElement(_CreatePkcs7Document_QNAME, byte[].class, CreatePkcs7.class, (byte[]) var1);
    }
}