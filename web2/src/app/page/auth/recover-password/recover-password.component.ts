import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { T_dict } from '../../../app.types';
import { T } from './recover-password.translate';
import { LangService } from '../../../service/session/lang.service';
import { AuthService } from '../../../service/session/auth.service';

@Component({
  selector: 'b-recover-password',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './recover-password.component.html',
  styleUrl: './recover-password.component.css',
})
export class RecoverPasswordComponent {
  private translates: T_dict = T;

  public step: 1 | 2 = 1;
  public login_value: string = '';
  public code_value: string = '';
  public token: string = '';
  public main_contact: string = '';
  public has_alert: boolean = false;
  public alert_message: string = '';

  constructor(
    private langService: LangService,
    private auth: AuthService,
    private activatedRoute: ActivatedRoute,
    private router: Router
  ) {}

  // step-1
  getOtpCode() {
    this.auth.sendRecoverOtpCode(this.login_value).subscribe(
      (next) => {
        this.token = next.token;
        this.main_contact = next.main_contact;
        this.step = 2;
        this.clearAlert();
      },
      (err) => this.alert(err.error)
    );
  }

  // step-2
  verifyOtpCode() {
    this.auth.checkRecoverOtpCode(this.token, this.code_value).subscribe(
      (next) => {
        if (next.status === 'S') {
          let queryParams = {
            token: this.token,
            code: this.code_value,
          };
          this.router.navigate(['../change_password'], {
            queryParams,
            relativeTo: this.activatedRoute,
          });
        } else {
          this.alert(next.result);
        }
      },
      (err) => this.alert(err.error)
    );
  }

  instruction2() {
    return this.t('instruction_2').replace('$1', this.main_contact);
  }

  back() {
    this.clearAlert();
    if (this.step === 1) {
      this.router.navigate(['../']);
    } else if (this.step === 2) {
      this.token = '';
      this.main_contact = '';
      this.step--;
    }
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
