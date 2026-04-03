using System.ComponentModel.DataAnnotations;

namespace FlotteAPI.Models;

public class Acheteur
{
    public int Id { get; set; }

    [Required]
    [StringLength(200)]
    public string Nom { get; set; } = string.Empty;

    [Required]
    [StringLength(200)]
    public string Prenom { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    [StringLength(200)]
    public string Email { get; set; } = string.Empty;

    [StringLength(20)]
    public string? Telephone { get; set; }
}

