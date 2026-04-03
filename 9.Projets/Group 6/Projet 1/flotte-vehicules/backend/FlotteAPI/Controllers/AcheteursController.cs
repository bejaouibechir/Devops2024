using FlotteAPI.Data;
using FlotteAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlotteAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AcheteursController : ControllerBase
{
    private readonly FlotteDbContext _db;

    public AcheteursController(FlotteDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<ActionResult<List<Acheteur>>> GetAll()
    {
        try
        {
            var items = await _db.Acheteurs.AsNoTracking().OrderBy(a => a.Nom).ThenBy(a => a.Prenom).ToListAsync();
            return Ok(items);
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<Acheteur>> GetById(int id)
    {
        try
        {
            var item = await _db.Acheteurs.AsNoTracking().FirstOrDefaultAsync(a => a.Id == id);
            return item is null ? NotFound() : Ok(item);
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpPost]
    public async Task<ActionResult<Acheteur>> Create([FromBody] Acheteur acheteur)
    {
        if (!ModelState.IsValid) return ValidationProblem(ModelState);

        try
        {
            _db.Acheteurs.Add(acheteur);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = acheteur.Id }, acheteur);
        }
        catch (DbUpdateException)
        {
            return Conflict("Email déjà utilisé.");
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<Acheteur>> Update(int id, [FromBody] Acheteur acheteur)
    {
        if (id != acheteur.Id) return BadRequest("Id incohérent.");
        if (!ModelState.IsValid) return ValidationProblem(ModelState);

        try
        {
            var existing = await _db.Acheteurs.FirstOrDefaultAsync(a => a.Id == id);
            if (existing is null) return NotFound();

            existing.Nom = acheteur.Nom;
            existing.Prenom = acheteur.Prenom;
            existing.Email = acheteur.Email;
            existing.Telephone = acheteur.Telephone;

            await _db.SaveChangesAsync();
            return Ok(existing);
        }
        catch (DbUpdateException)
        {
            return Conflict("Email déjà utilisé.");
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
            var existing = await _db.Acheteurs.FirstOrDefaultAsync(a => a.Id == id);
            if (existing is null) return NotFound();

            _db.Acheteurs.Remove(existing);
            await _db.SaveChangesAsync();
            return NoContent();
        }
        catch
        {
            return StatusCode(500, "Erreur serveur.");
        }
    }
}

