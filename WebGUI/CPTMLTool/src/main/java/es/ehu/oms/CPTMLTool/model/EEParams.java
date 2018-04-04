package es.ehu.oms.CPTMLTool.model;

public class EEParams {
	
	private double temp;
	private double time;
	private double load;
	
	private double minTemp;
	private double maxTemp;
	private double stepTemp;
	
	private double minTime;
	private double maxTime;
	private double stepTime;
	
	private double minLoad;
	private double maxLoad;
	private double stepLoad;
	
	private double quiral;
	private boolean scanVars;
	private boolean scanSol;
	private boolean scanCat;
	private boolean scanNuc;
	private boolean scanSub;
	
	private boolean predict;
	
	private byte[] file;	
	
	private String idReaction;
	private String contentProd;
	private String contentSubs;
	private String contentCat;
	private String contentSolv;
	private String contentNuc;
	
	public double getTemp() {
		return temp;
	}
	
	
	public EEParams()
	{
		this.time = 0.5;
		this.temp = 70;
		this.load = 2;
		
		this.maxTemp = 70;
		this.minTemp = -78;
		this.stepTemp = 20;
		
		this.maxTime = 72;
		this.minTime = 0.5;
		this.stepTime = 5;
		
		this.maxLoad = 5;
		this.minLoad = 2;
		this.stepLoad = 1;
	}
	
	public void setTemp(double temp) {
		this.temp = temp;
	}
	public double getTime() {
		return time;
	}
	
	
	public void setTime(double time) {
		this.time = time;
	}
	public double getLoad() {
		return load;
	}
	
	
	public void setLoad(double load) {
		this.load = load;
	}
	
	
	public double getMinTemp() {
		return minTemp;
	}
	public void setMinTemp(double minTemp) {
		this.minTemp = minTemp;
	}
	
	
	public double getMaxTemp() {
		return maxTemp;
	}
	public void setMaxTemp(double maxTemp) {
		this.maxTemp = maxTemp;
	}
	
	
	public double getStepTemp() {
		return stepTemp;
	}
	public void setStepTemp(double stepTemp) {
		this.stepTemp = stepTemp;
	}
	
	
	public double getMinTime() {
		return minTime;
	}
	public void setMinTime(double minTime) {
		this.minTime = minTime;
	}
	
	
	public double getMaxTime() {
		return maxTime;
	}
	public void setMaxTime(double maxTime) {
		this.maxTime = maxTime;
	}
	
	
	public double getStepTime() {
		return stepTime;
	}
	public void setStepTime(double stepTime) {
		this.stepTime = stepTime;
	}
	
	
	public double getMinLoad() {
		return minLoad;
	}
	public void setMinLoad(double minLoad) {
		this.minLoad = minLoad;
	}
	
	
	public double getMaxLoad() {
		return maxLoad;
	}
	public void setMaxLoad(double maxLoad) {
		this.maxLoad = maxLoad;
	}
	
	
	public double getStepLoad() {
		return stepLoad;
	}
	public void setStepLoad(double stepLoad) {
		this.stepLoad = stepLoad;
	}
	
	
	public double getQuiral() {
		return quiral;
	}
	public void setQuiral(double quiral) {
		this.quiral = quiral;
	}	
	
	public byte[] getFile() {
		return file;
	}
	public void setFile(byte[] file) {
		this.file = file;
	}
		
	public boolean isScanVars() {
		return scanVars;
	}


	public void setScanVars(boolean scanVars) {
		this.scanVars = scanVars;
	}


	public boolean isScanSol() {
		return scanSol;
	}


	public void setScanSol(boolean scanSol) {
		this.scanSol = scanSol;
	}


	public boolean isScanCat() {
		return scanCat;
	}


	public void setScanCat(boolean scanCat) {
		this.scanCat = scanCat;
	}


	public boolean isScanNuc() {
		return scanNuc;
	}


	public void setScanNuc(boolean scanNuc) {
		this.scanNuc = scanNuc;
	}


	public boolean isScanSub() {
		return scanSub;
	}


	public void setScanSub(boolean scanSub) {
		this.scanSub = scanSub;
	}


	public String getIdReaction() {
		return idReaction;
	}

	public void setIdReaction(String idReaction) {
		this.idReaction = idReaction;
	}


	public String getContentProd() {
		return contentProd;
	}
	public void setContentProd(String contentProd) {
		this.contentProd = contentProd;
	}
	
	
	public String getContentSubs() {
		return contentSubs;
	}
	public void setContentSubs(String contentSubs) {
		this.contentSubs = contentSubs;
	}
	
	
	public String getContentCat() {
		return contentCat;
	}
	public void setContentCat(String contentCat) {
		this.contentCat = contentCat;
	}
	
	
	public String getContentSolv() {
		return contentSolv;
	}
	public void setContentSolv(String contentSolv) {
		this.contentSolv = contentSolv;
	}
	
	
	public String getContentNuc() {
		return contentNuc;
	}
	public void setContentNuc(String contentNuc) {
		this.contentNuc = contentNuc;
	}


	public boolean isPredict() {
		return predict;
	}


	public void setPredict(boolean predict) {
		this.predict = predict;
	}
	
	
	
}
