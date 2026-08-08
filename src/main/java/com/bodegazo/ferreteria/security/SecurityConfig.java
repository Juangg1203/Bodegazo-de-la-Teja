package com.bodegazo.ferreteria.security;

import jakarta.servlet.DispatcherType;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.rememberme.InMemoryTokenRepositoryImpl;
import org.springframework.security.web.authentication.rememberme.PersistentTokenRepository;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

/**
 * Configuración central de Spring Security.
 *
 * Roles del sistema:
 *  - ROLE_CLIENTE
 *  - ROLE_EMPLEADO
 *  - ROLE_JEFE_BODEGA
 *  - ROLE_ADMINISTRADOR
 *
 * La autenticación real contra la tabla "usuarios" se realiza mediante
 * CustomUserDetailsService + DaoAuthenticationProvider (ver más abajo).
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    private final CustomUserDetailsService customUserDetailsService;

    public SecurityConfig(CustomUserDetailsService customUserDetailsService) {
        this.customUserDetailsService = customUserDetailsService;
    }

    private static final String[] RECURSOS_PUBLICOS = {
            "/", "/inicio", "/nosotros", "/contacto",
            "/productos", "/productos/**",
            "/impermeabilizantes", "/impermeabilizantes/**",
            "/tejas-upvc", "/tejas-upvc/**",
            "/login", "/registro", "/recuperar-password",
            "/error/**", "/mantenimiento",
            "/static/**", "/css/**", "/js/**", "/images/**", "/icons/**", "/fonts/**",
            "/webjars/**", "/favicon.ico", "/robots.txt", "/sitemap.xml"
    };

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    /**
     * Conecta el CustomUserDetailsService (consulta la tabla "usuarios")
     * con el PasswordEncoder BCrypt para validar credenciales.
     */
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(customUserDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PersistentTokenRepository persistentTokenRepository() {
        // NOTA: para producción se recomienda JdbcTokenRepositoryImpl contra la
        // tabla "usuarios_remember_me_tokens" (incluida en el script SQL).
        return new InMemoryTokenRepositoryImpl();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authenticationProvider(authenticationProvider())
            .authorizeHttpRequests(auth -> auth
                // Los forwards internos (ej. hacia /WEB-INF/jsp/... al renderizar una
                // vista JSP) no deben re-evaluarse como si fueran una petición nueva
                // del navegador — si no, cualquier página (hasta las públicas) termina
                // bloqueada porque /WEB-INF/jsp/** nunca coincide con las rutas
                // públicas declaradas más abajo.
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR, DispatcherType.INCLUDE).permitAll()
                .requestMatchers(RECURSOS_PUBLICOS).permitAll()
                .requestMatchers("/dashboard/**").authenticated()
                .requestMatchers("/perfil/**").authenticated()
                .requestMatchers("/calculadora-mantos", "/calculadora-tejas", "/calculadora-tejas/pdf")
                    .hasAnyRole("EMPLEADO", "JEFE_BODEGA", "ADMINISTRADOR")
                .requestMatchers("/cotizaciones/**").hasAnyRole("CLIENTE", "EMPLEADO", "JEFE_BODEGA", "ADMINISTRADOR")
                .requestMatchers("/ventas/**").hasAnyRole("EMPLEADO", "JEFE_BODEGA", "ADMINISTRADOR")
                .requestMatchers("/inventario/**").hasAnyRole("JEFE_BODEGA", "ADMINISTRADOR")
                .requestMatchers("/usuarios/**", "/configuracion/**", "/reportes/**").hasRole("ADMINISTRADOR")
                .requestMatchers("/administracion/**").hasAnyRole("ADMINISTRADOR", "JEFE_BODEGA")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .loginProcessingUrl("/login")
                .usernameParameter("correo")
                .passwordParameter("password")
                .defaultSuccessUrl("/dashboard", false)
                .failureUrl("/login?error=true")
                .permitAll()
            )
            .logout(logout -> logout
                .logoutRequestMatcher(new AntPathRequestMatcher("/logout"))
                .logoutSuccessUrl("/login?logout=true")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID", "remember-me")
                .permitAll()
            )
            .rememberMe(remember -> remember
                .key("bodegazoRememberMeKey")
                .tokenRepository(persistentTokenRepository())
                .tokenValiditySeconds(1209600) // 14 días
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                // NOTA: se quitó maximumSessions(1) temporalmente. Combinado con los
                // reinicios en caliente de Spring DevTools durante desarrollo, el
                // registro de sesiones en memoria queda inconsistente con las cookies
                // ya emitidas por el navegador y puede producir un bucle de
                // redirección hacia /login. Se puede volver a activar cuando ya no
                // se dependa del hot-reload (por ejemplo, en producción).
            )
            .exceptionHandling(ex -> ex
                .accessDeniedPage("/error/403")
            )
            // CSRF habilitado por defecto (protección para todos los formularios JSP).
            // XSS: mitigado mediante escape automático en JSTL <c:out> y cabeceras
            // de seguridad por defecto de Spring Security (X-Content-Type-Options,
            // X-Frame-Options, etc.), configuradas a continuación.
            .headers(headers -> headers
                .contentTypeOptions(contentType -> {})
                .frameOptions(frame -> frame.sameOrigin())
            );

        return http.build();
    }
}
