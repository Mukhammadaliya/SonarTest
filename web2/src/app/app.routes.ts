import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    redirectTo: 'auth',
  },
  {
    path: 'auth',
    loadComponent: () => import('./page/auth/auth.component').then(f => f.AuthComponent),
    loadChildren: () => import('./page/auth/auth.routes').then(f => f.routes),
  },
  {
    path: '**',
    loadComponent: () => import('./page/not-found/not-found.component').then(f => f.NotFoundComponent),
  },
];
