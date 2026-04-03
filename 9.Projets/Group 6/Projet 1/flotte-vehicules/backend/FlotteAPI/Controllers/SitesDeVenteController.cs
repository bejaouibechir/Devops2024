using FlotteAPI.Data;
using FlotteAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlotteAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SitesDeVenteController : ControllerBase
{
    private readonly FlotteDbContext _db;

    public SitesDeVenteController(FlotteDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<ActionResult<List<SiteDeVente>>> GetAll()
    {
        try
        {
            var items = await _db.SitesDeVente.AsNoTracking().OrderBy(s => s.Nom).ToListAsync();
            return Ok(items);
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<SiteDeVente>> GetById(int id)
    {
        try
        {
            var item = await _db.SitesDeVente.AsNoTracking().FirstOrDefaultAsync(s => s.Id == id);
            return item is null ? NotFound() : Ok(item);
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpPost]
    public async Task<ActionResult<SiteDeVente>> Create([FromBody] SiteDeVente site)
    {
        if (!ModelState.IsValid) return ValidationProblem(ModelState);

        try
        {
            _db.SitesDeVente.Add(site);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = site.Id }, site);
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<SiteDeVente>> Update(int id, [FromBody] SiteDeVente site)
    {
        if (id != site.Id) return BadRequest("Id incohérent.");
        if (!ModelState.IsValid) return ValidationProblem(ModelState);

        try
        {
            var existing = await _db.SitesDeVente.FirstOrDefaultAsync(s => s.Id == id);
            if (existing is null) return NotFound();

            existing.Nom = site.Nom;
            existing.Ville = site.Ville;
            existing.Adresse = site.Adresse;
            existing.Responsable = site.Responsable;

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
            var existing = await _db.SitesDeVente.FirstOrDefaultAsync(s => s.Id == id);
            if (existing is null) return NotFound();

            _db.SitesDeVente.Remove(existing);
            await _db.SaveChangesAsync();
            return NoContent();
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }
}

