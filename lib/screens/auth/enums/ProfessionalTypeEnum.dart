enum ProfessionalType {
  Medico,
  Enfermeiro,
  Fisioterapeuta,
  Fonoaudiologo,
  TecnicoEnfermagem
}

extension ProfessionalTypeExtension on ProfessionalType {
  int get value {
    switch (this) {
      case ProfessionalType.Medico:
        return 0;
      case ProfessionalType.Enfermeiro:
        return 1;
      case ProfessionalType.Fisioterapeuta:
        return 2;
      case ProfessionalType.Fonoaudiologo:
        return 3;
      case ProfessionalType.TecnicoEnfermagem:
        return 4;
    }
  }

  String get label {
    switch (this) {
      case ProfessionalType.Medico:
        return 'Médico';
      case ProfessionalType.Enfermeiro:
        return 'Enfermeiro';
      case ProfessionalType.Fisioterapeuta:
        return 'Fisioterapeuta';
      case ProfessionalType.Fonoaudiologo:
        return 'Fonoaudiólogo';
      case ProfessionalType.TecnicoEnfermagem:
        return 'Técnico de Enfermagem';
    }
  }

  static int getValueByLabel(String? label) {
    switch (label) {
      case 'Médico':
        return ProfessionalType.Medico.value;
      case 'Enfermeiro':
        return ProfessionalType.Enfermeiro.value;
      case 'Fisioterapeuta':
        return ProfessionalType.Fisioterapeuta.value;
      case 'Fonoaudiólogo':
        return ProfessionalType.Fonoaudiologo.value;
      case 'Técnico de Enfermagem':
        return ProfessionalType.TecnicoEnfermagem.value;
    }
    throw Exception('Invalid label: $label');
  }
}
