import { Component } from '@angular/core';

@Component({
  selector: 'b-not-found',
  standalone: true,
  template: `
    <div class="w-100 h-100 d-flex align-items-center justify-content-center">
      <h1>
        <span class="text-danger">404</span>
        not found
      </h1>
    </div>
  `,
})
export class NotFoundComponent {}
