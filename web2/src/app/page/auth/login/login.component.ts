import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { env } from '../../../../environments/env';
import { T_dict } from '../../../app.types';
import { T } from './login.translate';
import { LangService } from '../../../service/session/lang.service';
import { AuthService } from '../../../service/session/auth.service';
import { LoginByOtpComponent } from '../login-by-otp/login-by-otp.component';

@Component({
  selector: 'b-login',
  standalone: true,
  imports: [FormsModule, RouterLink, LoginByOtpComponent],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css',
})
export class LoginComponent {
  private translates: T_dict = T;

  public login_value: string = '';
  public password_value: string = '';
  public step: 1 | 2 = 1;
  public otp?: { token: string; expires_in: number };
  public has_alert: boolean = false;
  public alert_message: string = '';

  constructor(private langService: LangService, private auth: AuthService) {}

  onSubmit() {
    this.clearAlert();
    if (!this.login_value) {
      this.alert(this.t('login field is not filled'));
      return;
    }
    if (!this.password_value) {
      this.alert(this.t('password field is not filled'));
      return;
    }
    this.auth.login(this.login_value, this.password_value).subscribe(
      (next) => {
        if (next.status === 'logged_in') {
          if (env.is_prod) {
            window.location.replace(next.redirect_url);
          } else {
            window.location.replace(
              'http://localhost:9090' + next.redirect_url
            );
          }
        } else if (next.status === 'pending_verification') {
          this.otp = {
            token: next.token,
            expires_in: next.expires_in,
          };
          this.step = 2;
        }
      },
      (err) => {
        if (err.status === 429) {
          this.alert(this.t('too many attempts'));
        } else if (err.status === 403) {
          this.alert(this.t('forbidden'));
        } else {
          this.alert(err.error);
        }
      }
    );
  }

  back() {
    this.otp = undefined;
    this.step = 1;
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
