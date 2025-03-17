enum SMSType {
  forgotPassword,
  accountActivation,
}

int getSMSType(SMSType type) {
  switch (type) {
    case SMSType.forgotPassword:
      return 1;
    case SMSType.accountActivation:
      return 5;
    default:
      return 1;
  }
}
