class ValidationUtils {
  static List<String> validateEmail(String email) {
    final List<String> failedEmailSignUpCriteria = [];
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    // Check if email matches the valid format
    if (!emailRegex.hasMatch(email)) {
      failedEmailSignUpCriteria.add(
        'Email must be in a valid format (e.g., spamdefender@gmail.com).',
      );
    }

    return failedEmailSignUpCriteria;
  }

  static List<String> validateUsername(String username) {
    final List<String> failedUsernameSignUpCriteria = [];

    if(username.length > 37){
      failedUsernameSignUpCriteria.add('Username must be 37 characters or less');
    }

    return failedUsernameSignUpCriteria;
  }

  static List<String> validatePassword(String password) {
    final List<String> failedPasswordSignUpCriteria = [];
    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]).{12,}$',
    );

    // Check password length
    if (password.length < 6) {
      failedPasswordSignUpCriteria.add('be at least 6 characters long');
    }

    // check password length maximum
    if (password.length > 37) {
      failedPasswordSignUpCriteria.add('be 37 characters or less');
    }
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      failedPasswordSignUpCriteria.add(
        'contain at least one uppercase letter',
      );
    }
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      failedPasswordSignUpCriteria.add(
        'contain at least one lowercase letter',
      );
    }
    // Check for at least one digit
    if (!RegExp(r'\d').hasMatch(password)) {
      failedPasswordSignUpCriteria.add('contain at least one digit');
    }
    // Check for at least one special character
    if (!passwordRegex.hasMatch(password)) {
      failedPasswordSignUpCriteria.add(
        'contain at least one special character',
      );
    }

    return failedPasswordSignUpCriteria;
  }
}