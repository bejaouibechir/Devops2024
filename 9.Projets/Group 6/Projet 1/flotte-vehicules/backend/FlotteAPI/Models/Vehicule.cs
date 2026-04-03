using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FlotteAPI.Models;

public class Vehicule
{
    public int Id { get; set; }

    [Required]
    [StringLength(100)]
    public string Marque { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string Modele { get; set; } = string.Empty;

    [Required]
    [Range(1900, 2100)]
    public int Annee { get; set; }

    [Required]
    [Range(0, int.MaxValue)]
    public int Kilometrage { get; set; }

    [Required]
    [Range(typeof(decimal), "0", "79228162514264337593543950335")]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Prix { get; set; }

    [Required]
    [RegularExpression("^(Disponible|Vendu)$")]
    [StringLength(50)]
    public string Statut { get; set; } = "Disponible";

    public int? SiteDeVenteId { get; set; }
    public SiteDeVente? SiteDeVente { get; set; }

    public int? AcheteurId { get; set; }
    public Acheteur? Acheteur { get; set; }
}

