using FlotteAPI.Data;
using FlotteAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlotteAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class VehiculesController : ControllerBase
{
    private readonly FlotteDbContext _db;

    public VehiculesController(FlotteDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<ActionResult<List<Vehicule>>> GetAll()
    {
        try
        {
            var items = await _db.Vehicules
                .AsNoTracking()
                .Include(v => v.SiteDeVente)
                .Include(v => v.Acheteur)
                .OrderByDescending(v => v.Id)
                .ToListAsync();

            return Ok(items);
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<Vehicule>> GetById(int id)
    {
        try
        {
            var item = await _db.Vehicules
                .AsNoTracking()
                .Include(v => v.SiteDeVente)
                .Include(v => v.Acheteur)
                .FirstOrDefaultAsync(v => v.Id == id);

            return item is null ? NotFound() : Ok(item);
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpPost]
    public async Task<ActionResult<Vehicule>> Create([FromBody] Vehicule vehicule)
    {
        if (!ModelState.IsValid) return ValidationProblem(ModelState);

        try
        {
            if (vehicule.SiteDeVenteId is not null)
            {
                var siteOk = await _db.SitesDeVente.AnyAsync(s => s.Id == vehicule.SiteDeVenteId);
                if (!siteOk) return BadRequest("SiteDeVenteId invalide.");
            }

            if (vehicule.AcheteurId is not null)
            {
                var acheteurOk = await _db.Acheteurs.AnyAsync(a => a.Id == vehicule.AcheteurId);
                if (!acheteurOk) return BadRequest("AcheteurId invalide.");
            }

            _db.Vehicules.Add(vehicule);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = vehicule.Id }, vehicule);
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<Vehicule>> Update(int id, [FromBody] Vehicule vehicule)
    {
        if (id != vehicule.Id) return BadRequest("Id incohérent.");
        if (!ModelState.IsValid) return ValidationProblem(ModelState);

        try
        {
            var existing = await _db.Vehicules.FirstOrDefaultAsync(v => v.Id == id);
            if (existing is null) return NotFound();

            if (vehicule.SiteDeVenteId is not null)
            {
                var siteOk = await _db.SitesDeVente.AnyAsync(s => s.Id == vehicule.SiteDeVenteId);
                if (!siteOk) return BadRequest("SiteDeVenteId invalide.");
            }

            if (vehicule.AcheteurId is not null)
            {
                var acheteurOk = await _db.Acheteurs.AnyAsync(a => a.Id == vehicule.AcheteurId);
                if (!acheteurOk) return BadRequest("AcheteurId invalide.");
            }

            existing.Marque = vehicule.Marque;
            existing.Modele = vehicule.Modele;
            existing.Annee = vehicule.Annee;
            existing.Kilometrage = vehicule.Kilometrage;
            existing.Prix = vehicule.Prix;
            existing.Statut = vehicule.Statut;
            existing.SiteDeVenteId = vehicule.SiteDeVenteId;
            existing.AcheteurId = vehicule.AcheteurId;

            await _db.SaveChangesAsync();
            return Ok(existing);
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        try
        {
            var existing = await _db.Vehicules.FirstOrDefaultAsync(v => v.Id == id);
            if (existing is null) return NotFound();

            _db.Vehicules.Remove(existing);
            await _db.SaveChangesAsync();
            return NoContent();
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }
}

