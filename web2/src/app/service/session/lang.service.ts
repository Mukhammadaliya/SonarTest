import { Injectable } from '@angular/core';
import * as _ from 'underscore';
import { Lang, Lang_Code } from '../../app.types';

@Injectable({ providedIn: 'root' })
export class LangService {
  private lang: Lang;
  private storage_key = 'session_lang';

  all_langs: Lang[] = [
    { name: 'Русский', short_name: 'РУС', code: 'ru' },
    { name: 'English', short_name: 'ENG', code: 'en' },
    { name: 'Oʻzbek', short_name: 'OʻZB', code: 'uz' },
    { name: 'Қазақ', short_name: 'ҚАЗ', code: 'kk' },
  ];

  constructor() {
    // Begin: init lang
    let lang: Lang | undefined;
    let def_lang: Lang_Code = 'ru';
    if (!_.findWhere(this.all_langs, { code: def_lang })) {
      def_lang = (_.first(this.all_langs) as Lang).code;
    }
    let raw_local_storage = window.localStorage.getItem(this.storage_key);
    if (raw_local_storage) {
      lang = _.findWhere(this.all_langs, JSON.parse(raw_local_storage));
    } else {
      lang = _.findWhere(this.all_langs, { code: def_lang });
    }
    this.lang = lang as Lang;
    // End: init lang
  }

  getLang() {
    return this.lang;
  }

  setLang(lang: Lang): void {
    window.localStorage.setItem(
      this.storage_key,
      JSON.stringify({ code: lang.code })
    );
    this.lang = lang;
  }
}
