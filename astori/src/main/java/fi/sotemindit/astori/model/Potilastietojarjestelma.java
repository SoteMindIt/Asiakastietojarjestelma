package fi.sotemindit.astori.model;

public enum Potilastietojarjestelma {
	EI_TIEDOSSA("Ei tiedossa"),
	HILKKA("Hilkka"),
	DOMACARE("Domacare"),
	NURSEBUDDY("Nursebuddy"),
	ESKO("Esko"),
	LIFECARE("Lifecare"),
	APOTTI("Apotti"),
	OMNI360("Omni360"),
	SAGA("Saga"),
	PEGASOS("Pegasos"),
	MEDIATRI("Mediatri");

	private final String nimi;

	Potilastietojarjestelma(String nimi) {
		this.nimi = nimi;
	}

	public String getNimi() {
		return nimi;
	}

	public static Potilastietojarjestelma vanhastaArvosta(String arvo) {
		if (arvo != null) {
			for (Potilastietojarjestelma jarjestelma : values()) {
				if (jarjestelma != EI_TIEDOSSA
						&& (jarjestelma.name().equalsIgnoreCase(arvo.trim())
								|| jarjestelma.nimi.equalsIgnoreCase(arvo.trim()))) {
					return jarjestelma;
				}
			}
		}
		return EI_TIEDOSSA;
	}
}
