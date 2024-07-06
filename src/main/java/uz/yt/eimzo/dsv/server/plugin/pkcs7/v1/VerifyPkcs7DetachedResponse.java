package uz.yt.eimzo.dsv.server.plugin.pkcs7.v1;

import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "verifyPkcs7DetachedResponse", propOrder = {"_return"})
public class VerifyPkcs7DetachedResponse {
    @XmlElement(name = "return")
    protected String _return;

    public VerifyPkcs7DetachedResponse() {
    }

    public String getReturn() {
        return this._return;
    }

    public void setReturn(String var1) {
        this._return = var1;
    }
}