using FlotteAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace FlotteAPI.Data;

public class FlotteDbContext : DbContext
{
    public FlotteDbContext(DbContextOptions<FlotteDbContext> options) : base(options)
    {
    }

    public DbSet<Vehicule> Vehicules => Set<Vehicule>();
    public DbSet<Acheteur> Acheteurs => Set<Acheteur>();
    public DbSet<SiteDeVente> SitesDeVente => Set<SiteDeVente>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Acheteur>()
            .HasIndex(a => a.Email)
            .IsUnique();

        modelBuilder.Entity<Vehicule>()
            .Property(v => v.Prix)
            .HasColumnType("decimal(10,2)");

        modelBuilder.Entity<Vehicule>()
            .HasOne(v => v.SiteDeVente)
            .WithMany()
            .HasForeignKey(v => v.SiteDeVenteId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.SetNull);

        modelBuilder.Entity<Vehicule>()
            .HasOne(v => v.Acheteur)
            .WithMany()
            .HasForeignKey(v => v.AcheteurId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.SetNull);
    }
}

