import { Injectable } from '@angular/core';
import { LangService } from './lang.service';
import { SHA1 } from 'crypto-js';
import { Company, Map, Otp_Code, Phone_Uz, Yes_No } from '../../app.types';
import { HttpClient } from '@angular/common/http';

type Login_Reponse =
  | { status: 'logged_in'; redirect_url: string }
  | { status: 'pending_verification'; token: string; expires_in: number };

const api: Map = {
  login: '/b/core/s$log_in',
  get_company_infos_by_phone: '/b/core/m$get_company_infos_by_phone',
  gen_onetime_password: '/b/core/m$gen_onetime_password',
  resend_onetime_password: '/b/core/m$resend_onetime_password',
  logon_web_by_otp: '/b/core/s$logon_web_by_otp',
  send_recover_password_message: '/b/core/m$send_recover_password_message',
  check_recover_password_code: '/b/core/m$check_recover_password_code',
  change_password: '/b/core/m$change_password',
} as const;

@Injectable({ providedIn: 'root' })
export class AuthService {
  constructor(private langService: LangService, private http: HttpClient) {}

  login(login: string, password: string) {
    let payload: Map = {
      login: login,
      password: SHA1(password).toString(),
      lang_code: this.langService.getLang().code,
    };
    return this.http.post<Login_Reponse>(api['login'], payload);
  }

  getCompaniesByPhone(phone: Phone_Uz) {
    let payload: Map = {
      phone: phone.slice(1),
    };
    return this.http.post<Company[]>(
      api['get_company_infos_by_phone'],
      payload
    );
  }

  sendOtpCode(company_code: string, phone: Phone_Uz) {
    let payload = {
      code: company_code,
      phone: phone.slice(1),
      lang_code: this.langService.getLang().code,
    };
    return this.http.post<{ token: string; expires_in: number }>(
      api['gen_onetime_password'],
      payload
    );
  }

  resendOtpCode(token: string) {
    let payload = {
      token,
      lang_code: this.langService.getLang().code,
    };
    return this.http.post<{ token: string; expires_in: number }>(
      api['resend_onetime_password'],
      payload
    );
  }

  loginByOtp(token: string, otp_code: Otp_Code, remember_me: Yes_No) {
    let payload = [token, otp_code, remember_me];
    let http_options = {
      responseType: 'text',
    };
    return this.http.post<String>(
      api['logon_web_by_otp'],
      payload,
      http_options as any // TODO
    );
  }

  sendRecoverOtpCode(login: string) {
    let payload = {
      login,
      lang_code: this.langService.getLang().code,
      send_to_phone: 'Y',
    };
    return this.http.post<{
      expired_time: number;
      main_contact: string;
      token: string;
    }>(api['send_recover_password_message'], payload);
  }

  checkRecoverOtpCode(token: string, otp_code: string) {
    let payload = {
      token,
      code: otp_code,
      lang_code: this.langService.getLang().code,
    };
    return this.http.post<{ result: string; status: string }>(
      api['check_recover_password_code'],
      payload
    );
  }

  changePassword(password: string, token: string, otp_code: string) {
    let payload = {
      password,
      token,
      code: otp_code,
    };
    return this.http.post(api['change_password'], payload);
  }
}
