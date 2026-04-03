using System.ComponentModel.DataAnnotations;

namespace FlotteAPI.Models;

public class SiteDeVente
{
    public int Id { get; set; }

    [Required]
    [StringLength(200)]
    public string Nom { get; set; } = string.Empty;

    [Required]
    [StringLength(100)]
    public string Ville { get; set; } = string.Empty;

    [StringLength(300)]
    public string? Adresse { get; set; }

    [StringLength(200)]
    public string? Responsable { get; set; }
}

