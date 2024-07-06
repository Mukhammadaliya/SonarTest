import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    redirectTo: 'login',
  },
  {
    path: 'login',
    loadComponent: () => import('./login/login.component').then(f => f.LoginComponent),
  },
  {
    path: 'login_by_phone',
    loadComponent: () => import('./login-by-phone/login-by-phone.component').then(f => f.LoginByPhoneComponent),
  },
  {
    path: 'login_by_email',
    loadComponent: () => import('./login-by-email/login-by-email.component').then(f => f.LoginByEmailComponent),
  },
  {
    path: 'recover_password',
    loadComponent: () => import('./recover-password/recover-password.component').then(f => f.RecoverPasswordComponent),
  },
  {
    path: 'change_password',
    loadComponent: () => import('./change-password/change-password.component').then(f => f.ChangePasswordComponent),
  },
];
