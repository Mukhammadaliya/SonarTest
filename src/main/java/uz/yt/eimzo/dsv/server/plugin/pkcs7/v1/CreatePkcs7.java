package uz.yt.eimzo.dsv.server.plugin.pkcs7.v1;

import jakarta.xml.bind.JAXBElement;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlElementRef;
import jakarta.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "createPkcs7", propOrder = {"document", "apikey"})
public class CreatePkcs7 {
    @XmlElementRef(
            name = "document",
            type = JAXBElement.class,
            required = false
    )
    protected JAXBElement<byte[]> document;
    protected String apikey;

    public CreatePkcs7() {
    }

    public JAXBElement<byte[]> getDocument() {
        return this.document;
    }

    public void setDocument(JAXBElement<byte[]> var1) {
        this.document = var1;
    }

    public String getApikey() {
        return this.apikey;
    }

    public void setApikey(String var1) {
        this.apikey = var1;
    }
}