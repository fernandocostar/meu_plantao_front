class FormValidators {
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha não pode estar vazia';
    }
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if (value != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail não pode estar vazio';
    }
    // Simple email pattern validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Informe um e-mail válido';
    }
    return null;
  }
}
