import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Términos y condiciones",
          style: GoogleFonts.nunito(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Última actualización: Agosto 2026",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildTermSection(
              "1. Aceptación de los Términos",
              "Al descargar y utilizar la aplicación Parko, usted acepta cumplir y estar sujeto a los siguientes términos y condiciones de uso. Si no está de acuerdo con alguna parte de estos términos, no podrá utilizar el servicio.",
            ),
            _buildTermSection(
              "2. Descripción del Servicio",
              "Parko es una plataforma digital diseñada para facilitar la búsqueda y el pago de estacionamientos gestionados. El servicio permite a los usuarios de la UTN FRC gestionar sus vehículos y saldos de manera virtual.",
            ),
            _buildTermSection(
              "3. Registro de Usuario",
              "Para utilizar ciertas funciones, debe registrarse y mantener una cuenta activa. Usted es responsable de mantener la confidencialidad de su contraseña y de toda la actividad que ocurra bajo su cuenta.",
            ),
            _buildTermSection(
              "4. Gestión de Saldo y Pagos",
              "Los pagos realizados a través de la aplicación son finales. El saldo cargado en la billetera virtual de Parko es de uso exclusivo para los servicios ofrecidos dentro de la plataforma y no es reembolsable.",
            ),
            _buildTermSection(
              "5. Responsabilidad del Usuario",
              "Usted se compromete a proporcionar información veraz sobre sus vehículos y datos personales. Parko no se responsabiliza por multas o infracciones derivadas del ingreso incorrecto de patentes o el uso indebido de la plataforma.",
            ),
            _buildTermSection(
              "6. Privacidad",
              "Su privacidad es importante para nosotros. El uso de sus datos personales se rige por nuestra Política de Privacidad, la cual se incorpora a estos términos por referencia.",
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Parko v1.0.0 - Todos los derechos e izquierdos reservados",
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
