import { Component, OnInit, Output, Input, EventEmitter } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { env } from '../../../../environments/env';
import { T } from './login-by-otp.translate';
import { Otp_Code, T_dict, Yes_No } from '../../../app.types';
import { LangService } from '../../../service/session/lang.service';
import { AuthService } from '../../../service/session/auth.service';

@Component({
  selector: 'b-login-by-otp',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './login-by-otp.component.html',
  styleUrl: './login-by-otp.component.css',
})
export class LoginByOtpComponent implements OnInit {
  private translates: T_dict = T;

  @Output() returnBack = new EventEmitter();
  @Input({ required: true }) token?: string;
  @Input({ required: true }) expires_in?: number;

  public is_valid_init: boolean = true;
  public has_alert: boolean = false;
  public alert_message: string = '';
  public otp_code?: Otp_Code;
  public remember_me: boolean = true;
  public has_resend: boolean = false;
  public has_timer: boolean = false;
  public timer: number = 0;

  constructor(private langService: LangService, private auth: AuthService) {}

  ngOnInit(): void {
    if (!this.token) {
      this.is_valid_init = false;
      this.alert(this.t('token is not found'));
      return;
    }
    if (!this.expires_in) {
      this.is_valid_init = false;
      this.alert(this.t('expiration time is not found'));
      return;
    }
    this.setTimer(this.expires_in);
  }

  setTimer(expires_in: number) {
    this.timer = expires_in - 5;

    let x = setInterval(() => {
      this.timer--;
      if (this.timer <= 0) {
        clearInterval(x);
        this.has_timer = false;
        this.has_resend = true;
      }
    }, 1000);

    this.has_timer = true;
    this.has_resend = false;
  }

  resend() {
    this.clearAlert();
    this.otp_code = undefined;
    if (!this.token) {
      this.is_valid_init = false;
      this.alert(this.t('token is not found'));
      return;
    }
    this.auth.resendOtpCode(this.token).subscribe(
      (next) => {
        this.token = next.token;
        this.expires_in = next.expires_in;
        this.setTimer(this.expires_in);
      },
      (err) => this.alert(err.error)
    );
  }

  isValidCode(code: any): code is Otp_Code {
    return /^\d{6}$/.test(code);
  }

  onSubmit() {
    if (!this.token) {
      this.is_valid_init = false;
      this.alert(this.t('token is not found'));
      return;
    }
    if (!this.isValidCode(this.otp_code)) {
      this.alert(this.t('code is invalid'));
      return;
    }
    let remember_me: Yes_No = this.remember_me ? 'Y' : 'N';
    this.auth.loginByOtp(this.token, this.otp_code, remember_me).subscribe(
      (next) => {
        if (env.is_prod) {
          window.location.replace(next as any); // TODO
        } else {
          window.location.replace('http://localhost:9090' + next);
        }
      },
      (err) => this.alert(err.error)
    );
  }

  back() {
    this.returnBack.emit();
  }

  t(key: keyof typeof T): string {
    return this.translates[key][this.langService.getLang().code];
  }

  alert(message: string) {
    this.alert_message = message;
    this.has_alert = true;
  }

  clearAlert() {
    this.alert_message = '';
    this.has_alert = false;
  }
}
