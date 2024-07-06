import { Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { T_dict } from '../../../app.types';
import { T } from './change-password.translate';
import { LangService } from '../../../service/session/lang.service';
import { AuthService } from '../../../service/session/auth.service';
import { LoginByOtpComponent } from '../login-by-otp/login-by-otp.component';

@Component({
  selector: 'b-change-password',
  standalone: true,
  imports: [FormsModule, RouterLink, LoginByOtpComponent],
  templateUrl: './change-password.component.html',
  styleUrl: './change-password.component.css',
})
export class ChangePasswordComponent implements OnInit {
  private translates: T_dict = T;

  public is_valid_init: boolean = false;
  public is_succeeded: boolean = true;
  public token: string = '';
  public otp_code: string = '';
  public password_value: string = '';
  public confirm_password_value: string = '';
  public username: string = '';
  public has_alert: boolean = false;
  public alert_message: string = '';

  constructor(
    private langService: LangService,
    private auth: AuthService,
    private activatedRoute: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.activatedRoute.queryParams.subscribe((params) => {
      this.clearAlert();
      this.is_valid_init = true;
      this.token = params['token'];
      this.otp_code = params['code'];
      this.password_value = '';
      this.confirm_password_value = '';
      this.username = '';
      this.verifyOtpCode();
    });
  }

  verifyOtpCode() {
    if (!this.token || !this.otp_code) {
      this.is_valid_init = false;
      this.alert(this.t('token or otp code is not defined'));
      return;
    }
    this.auth.checkRecoverOtpCode(this.token, this.otp_code).subscribe(
      (next) => {
        if (next.status === 'S') {
          this.clearAlert();
          this.is_valid_init = true;
          this.username = next.result;
        } else {
          this.is_valid_init = false;
          this.alert(next.result);
        }
      },
      (err) => {
        this.is_valid_init = false;
        this.alert(err.error);
      }
    );
  }

  isValidPassword(): boolean {
    return this.password_value === this.confirm_password_value;
  }

  changePassword() {
    if (!this.token || !this.otp_code) {
      this.alert(this.t('token or otp code is not defined'));
      return;
    }
    if (!this.password_value || !this.confirm_password_value) {
      this.alert(this.t('password field is not filled'));
      return;
    }
    if (!this.isValidPassword()) {
      this.alert(this.t("confirm password field doesn't match"));
      return;
    }
    this.clearAlert();
    this.auth
      .changePassword(this.password_value, this.token, this.otp_code)
      .subscribe(
        (next) => {
          this.is_valid_init = false;
          this.clearAlert();
          this.is_succeeded = true;
        },
        (err) => this.alert(err.error)
      );
  }

  instruction() {
    return this.t('instruction').replace('$1', this.username);
  }

  back() {
    this.router.navigate(['../']);
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
