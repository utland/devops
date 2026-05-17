import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      'no-unused-vars': 'off', 
      
      '@typescript-eslint/no-unused-vars': [
        'error',
        {
          'args': 'none',                
          'caughtErrors': 'none',        
        }
      ],
      
      '@typescript-eslint/no-explicit-any': 'warn',
      'no-console': 'off',
    },
  },
  {
    ignores: ['dist/**', 'node_modules/**', 'coverage/**'],
  }
);