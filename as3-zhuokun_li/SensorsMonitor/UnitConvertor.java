public class UnitConvertor{
	private static final double VREF = 1.5;

	public static double convertTemp(double value){
		return -39.60 + 0.01*value;
	}
	public static double convertVoltage(double value){
		return value/4096 * VREF;
	}
	public static double convertLight(double value){
		double i = convertVoltage(value) / 100000;
		return 0.625 * 1000000 * i * 1000;
	}
	public static double convertHumidity(double value){
		return -4 + 0.0405*value + (-2.8 / 1000000)*(value*value);
	}
}