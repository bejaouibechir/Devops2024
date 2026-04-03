package com.stockmaster.dto.request;

import com.stockmaster.domain.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank
    private String username;
    @NotBlank
    private String password;
    @Email @NotBlank
    private String email;
    @NotNull
    private Role role;
}
