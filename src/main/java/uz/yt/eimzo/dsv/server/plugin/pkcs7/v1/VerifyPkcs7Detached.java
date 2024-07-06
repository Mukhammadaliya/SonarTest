package uz.yt.eimzo.dsv.server.plugin.pkcs7.v1;

import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlType;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "verifyPkcs7Detached", propOrder = {"dataB64", "pkcs7B64"})
public class VerifyPkcs7Detached {
    protected String dataB64;
    protected String pkcs7B64;

    public VerifyPkcs7Detached() {
    }

    public String getDataB64() {
        return this.dataB64;
    }

    public void setDataB64(String var1) {
        this.dataB64 = var1;
    }

    public String getPkcs7B64() {
        return this.pkcs7B64;
    }

    public void setPkcs7B64(String var1) {
        this.pkcs7B64 = var1;
    }
}