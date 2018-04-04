package es.ehu.oms.CPTMLTool.model;

public class MMDParams {

	private boolean means;
	private boolean singular;
	
	//Atom properties
	private boolean zv;
	private boolean vvdw;
	private boolean aPolar;
	private boolean sae;
	private boolean ea;	
	private boolean noneAtProp;
	
	//Atom Types	
	private boolean allAtoms;
	private boolean cSat;
	private boolean cUns;
	private boolean hal;
	private boolean het;
	private boolean hetNoX;
	
	private byte[] file;	
	private String content;
	

	public MMDParams()
	{
		this.means = true;
		this.singular = true;
		this.zv = true;
		this.vvdw = true;
		this.aPolar = true;
		this.sae = true;
		this.ea = true;
		this.noneAtProp = false;
		
		this.allAtoms = true;
		this.cSat = true;
		this.cUns = true;
		this.hal = true;
		this.het = true;
		this.hetNoX = true;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public byte[] getFile() {
		return file;
	}

	public void setFile(byte[] file) {
		this.file = file;
	}	
	
	
	public boolean isMeans() {
		return means;
	}
	public void setMeans(boolean means) {
		this.means = means;
	}
	public boolean isSingular() {
		return singular;
	}
	public void setSingular(boolean singular) {
		this.singular = singular;
	}
	public boolean isZv() {
		return zv;
	}
	public void setZv(boolean zv) {
		this.zv = zv;
	}
	public boolean isVvdw() {
		return vvdw;
	}
	public void setVvdw(boolean vvdw) {
		this.vvdw = vvdw;
	}
	public boolean isaPolar() {
		return aPolar;
	}
	public void setaPolar(boolean aPolar) {
		this.aPolar = aPolar;
	}
	public boolean isSae() {
		return sae;
	}
	public void setSae(boolean sae) {
		this.sae = sae;
	}
	public boolean isEa() {
		return ea;
	}
	public void setEa(boolean ea) {
		this.ea = ea;
	}
	
	public boolean isNoneAtProp() {
		return noneAtProp;
	}

	public void setNoneAtProp(boolean noneAtProp) {
		this.noneAtProp = noneAtProp;
	}

	public boolean isAllAtoms() {
		return allAtoms;
	}

	public void setAllAtoms(boolean allAtoms) {
		this.allAtoms = allAtoms;
	}

	public boolean iscSat() {
		return cSat;
	}

	public void setcSat(boolean cSat) {
		this.cSat = cSat;
	}

	public boolean iscUns() {
		return cUns;
	}

	public void setcUns(boolean cUns) {
		this.cUns = cUns;
	}

	public boolean isHal() {
		return hal;
	}

	public void setHal(boolean hal) {
		this.hal = hal;
	}

	public boolean isHet() {
		return het;
	}

	public void setHet(boolean het) {
		this.het = het;
	}

	public boolean isHetNoX() {
		return hetNoX;
	}

	public void setHetNoX(boolean hetNoX) {
		this.hetNoX = hetNoX;
	}
	
	
	
	
}
