import { isDevMode } from '@angular/core';

export const env = {
  is_prod: !isDevMode(),
} as const;
