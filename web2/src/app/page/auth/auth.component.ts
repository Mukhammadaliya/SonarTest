import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import * as _ from 'underscore';
import { Lang, T_dict } from '../../app.types';
import { NgbDropdownModule } from '@ng-bootstrap/ng-bootstrap';
import { T } from './auth.translate';
import { LangService } from '../../service/session/lang.service';

@Component({
  selector: 'b-auth',
  standalone: true,
  imports: [RouterOutlet, NgbDropdownModule],
  templateUrl: './auth.component.html',
  styleUrl: './auth.component.css',
})
export class AuthComponent {
  private translates: T_dict = T;

  public lang: Lang;
  public all_langs: Lang[];
  public current_year: number = new Date().getFullYear();

  constructor(private langService: LangService) {
    this.lang = langService.getLang();
    this.all_langs = langService.all_langs;
  }

  t(key: keyof typeof T): string {
    return this.translates[key][this.lang.code];
  }

  setLang(lang: Lang): void {
    this.langService.setLang(lang);
    this.lang = this.langService.getLang();
  }
}
