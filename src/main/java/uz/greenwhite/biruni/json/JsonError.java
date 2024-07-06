package uz.greenwhite.biruni.json;

public class JsonError extends RuntimeException {

	private static final long serialVersionUID = 6989517660277658562L;

	public JsonError(String message) {
		super(message);
	}
	
	public JsonError(int i) {
		super("Json parse error at:" + i);
	}
}
