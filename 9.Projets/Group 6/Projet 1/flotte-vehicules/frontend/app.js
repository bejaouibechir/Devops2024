(() => {
  const guessApiBase = () => {
    if (window.API_BASE_URL && typeof window.API_BASE_URL === "string") return window.API_BASE_URL;
    const host = window.location && window.location.hostname ? window.location.hostname : "localhost";
    return `http://${host}:5000`;
  };

  const API_BASE = guessApiBase();
  const apiLabel = document.getElementById("apiBase");
  if (apiLabel) apiLabel.textContent = API_BASE;

  const api = async (path, options = {}) => {
    const url = `${API_BASE}${path}`;
    try {
      const res = await fetch(url, {
        headers: { "Content-Type": "application/json", ...(options.headers || {}) },
        ...options,
      });
      const isJson = (res.headers.get("content-type") || "").includes("application/json");
      const body = isJson ? await res.json().catch(() => null) : await res.text().catch(() => "");
      if (!res.ok) {
        const msg = typeof body === "string" && body ? body : (body && body.title) ? body.title : `HTTP ${res.status}`;
        throw new Error(msg);
      }
      return body;
    } catch (e) {
      if (e && e.name === "TypeError") throw new Error("API inaccessible. Vérifiez que le backend tourne sur le port 5000.");
      throw e;
    }
  };

  const { createApp } = Vue;

  createApp({
    data() {
      return {
        tab: "vehicules",
        globalError: "",
        globalInfo: "",

        vehicules: [],
        acheteurs: [],
        sites: [],

        vehiculeForm: {
          id: null,
          marque: "",
          modele: "",
          annee: 2020,
          kilometrage: 0,
          prix: 0,
          statut: "Disponible",
          siteDeVenteId: null,
          acheteurId: null,
        },
        vehiculeError: "",

        acheteurForm: { id: null, nom: "", prenom: "", email: "", telephone: "" },
        acheteurError: "",

        siteForm: { id: null, nom: "", ville: "", adresse: "", responsable: "" },
        siteError: "",
      };
    },
    async mounted() {
      await this.loadAll();
    },
    methods: {
      formatMoney(v) {
        const n = Number(v ?? 0);
        return new Intl.NumberFormat("fr-FR", { style: "currency", currency: "EUR" }).format(n);
      },

      async loadAll() {
        this.globalError = "";
        this.globalInfo = "";
        try {
          await Promise.all([this.loadVehicules(), this.loadAcheteurs(), this.loadSites()]);
        } catch (e) {
          this.globalError = e.message || String(e);
        }
      },

      async loadVehicules() {
        this.vehicules = await api("/api/vehicules");
      },
      async loadAcheteurs() {
        this.acheteurs = await api("/api/acheteurs");
      },
      async loadSites() {
        this.sites = await api("/api/sitesdevente");
      },

      resetVehicule() {
        this.vehiculeError = "";
        this.vehiculeForm = {
          id: null,
          marque: "",
          modele: "",
          annee: 2020,
          kilometrage: 0,
          prix: 0,
          statut: "Disponible",
          siteDeVenteId: null,
          acheteurId: null,
        };
      },
      editVehicule(v) {
        this.vehiculeError = "";
        this.vehiculeForm = {
          id: v.id,
          marque: v.marque,
          modele: v.modele,
          annee: v.annee,
          kilometrage: v.kilometrage,
          prix: Number(v.prix),
          statut: v.statut,
          siteDeVenteId: v.siteDeVenteId ?? null,
          acheteurId: v.acheteurId ?? null,
        };
        this.tab = "vehicules";
      },
      async saveVehicule() {
        this.vehiculeError = "";
        try {
          const payload = { ...this.vehiculeForm };
          if (payload.siteDeVenteId === "") payload.siteDeVenteId = null;
          if (payload.acheteurId === "") payload.acheteurId = null;
          if (payload.id) {
            await api(`/api/vehicules/${payload.id}`, { method: "PUT", body: JSON.stringify(payload) });
            this.globalInfo = "Véhicule mis à jour.";
          } else {
            const created = await api("/api/vehicules", { method: "POST", body: JSON.stringify(payload) });
            this.globalInfo = `Véhicule créé (ID ${created.id}).`;
          }
          this.resetVehicule();
          await this.loadVehicules();
        } catch (e) {
          this.vehiculeError = e.message || String(e);
        }
      },
      async deleteVehicule(id) {
        if (!confirm("Supprimer ce véhicule ?")) return;
        try {
          await api(`/api/vehicules/${id}`, { method: "DELETE" });
          await this.loadVehicules();
        } catch (e) {
          this.globalError = e.message || String(e);
        }
      },

      resetAcheteur() {
        this.acheteurError = "";
        this.acheteurForm = { id: null, nom: "", prenom: "", email: "", telephone: "" };
      },
      editAcheteur(a) {
        this.acheteurError = "";
        this.acheteurForm = { id: a.id, nom: a.nom, prenom: a.prenom, email: a.email, telephone: a.telephone ?? "" };
        this.tab = "acheteurs";
      },
      async saveAcheteur() {
        this.acheteurError = "";
        try {
          const payload = { ...this.acheteurForm };
          if (payload.id) {
            await api(`/api/acheteurs/${payload.id}`, { method: "PUT", body: JSON.stringify(payload) });
            this.globalInfo = "Acheteur mis à jour.";
          } else {
            const created = await api("/api/acheteurs", { method: "POST", body: JSON.stringify(payload) });
            this.globalInfo = `Acheteur créé (ID ${created.id}).`;
          }
          this.resetAcheteur();
          await this.loadAcheteurs();
        } catch (e) {
          this.acheteurError = e.message || String(e);
        }
      },
      async deleteAcheteur(id) {
        if (!confirm("Supprimer cet acheteur ?")) return;
        try {
          await api(`/api/acheteurs/${id}`, { method: "DELETE" });
          await this.loadAcheteurs();
        } catch (e) {
          this.globalError = e.message || String(e);
        }
      },

      resetSite() {
        this.siteError = "";
        this.siteForm = { id: null, nom: "", ville: "", adresse: "", responsable: "" };
      },
      editSite(s) {
        this.siteError = "";
        this.siteForm = { id: s.id, nom: s.nom, ville: s.ville, adresse: s.adresse ?? "", responsable: s.responsable ?? "" };
        this.tab = "sites";
      },
      async saveSite() {
        this.siteError = "";
        try {
          const payload = { ...this.siteForm };
          if (payload.id) {
            await api(`/api/sitesdevente/${payload.id}`, { method: "PUT", body: JSON.stringify(payload) });
            this.globalInfo = "Site mis à jour.";
          } else {
            const created = await api("/api/sitesdevente", { method: "POST", body: JSON.stringify(payload) });
            this.globalInfo = `Site créé (ID ${created.id}).`;
          }
          this.resetSite();
          await this.loadSites();
        } catch (e) {
          this.siteError = e.message || String(e);
        }
      },
      async deleteSite(id) {
        if (!confirm("Supprimer ce site ? (les véhicules liés seront désassignés)")) return;
        try {
          await api(`/api/sitesdevente/${id}`, { method: "DELETE" });
          await this.loadSites();
          await this.loadVehicules();
        } catch (e) {
          this.globalError = e.message || String(e);
        }
      },
    },
  }).mount("#app");
})();

