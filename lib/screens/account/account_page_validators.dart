class AccountPageValidators {
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'O nome não pode estar vazio.';
    } else if (name.length < 3) {
      return 'Insira seu nome completo.';
    } else if (name.length > 30) {
      return 'O nome pode ter no máximo 30 caracteres. Fique à vontade para utilizar abreviações.';
    }
    return null;
  }

  static String? validateProfessionalRegister(String professionalRegister) {
    if (professionalRegister.isEmpty) {
      return 'O registro profissional não pode estar vazio.';
    } else if (!RegExp(r'^\d+$').hasMatch(professionalRegister)) {
      return 'O registro profissional deve conter apenas números.';
    } else if (professionalRegister.length != 6) { // Assuming a valid length of 6 digits
      return 'O registro profissional deve ter 6 dígitos.';
    }
    return null;
  }
}
