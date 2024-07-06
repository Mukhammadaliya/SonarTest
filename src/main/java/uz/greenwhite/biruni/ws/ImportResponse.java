package uz.greenwhite.biruni.ws;

import jakarta.xml.bind.annotation.*;
import java.util.ArrayList;

@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "response", propOrder = {
        "successes",
        "errors"
})
public class ImportResponse {
    @XmlElement(name = "successes")
    public ArrayList<Result> successes;
    @XmlElement(name = "errors")
    public ArrayList<Result> errors;

    @XmlAccessorType(XmlAccessType.FIELD)
    public static class Result {
        @XmlElement(name = "code", required = true)
        protected String code;

        @XmlElement(name = "message")
        protected String message;
    }
}
