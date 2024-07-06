import { Component } from '@angular/core';
import { NgClass } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { Company, T_dict } from '../../../app.types';
import { T } from './login-by-email.translate';
import { LangService } from '../../../service/session/lang.service';
import { AuthService } from '../../../service/session/auth.service';
import { LoginByOtpComponent } from '../login-by-otp/login-by-otp.component';

@Component({
  selector: 'b-login-by-email',
  standalone: true,
  imports: [FormsModule, NgClass, LoginByOtpComponent],
  templateUrl: './login-by-email.component.html',
  styleUrl: './login-by-email.component.css',
})
export class LoginByEmailComponent {
  private translates: T_dict = T;

  public step: 1 | 2 | 3 = 1;
  public email_value: string = '';
  public companies: Company[] = [];
  public otp?: { token: string; expires_in: number };
  public has_alert: boolean = false;
  public alert_message: string = '';

  constructor(
    private langService: LangService,
    private auth: AuthService,
    private router: Router
  ) {}

  // step-1
  getCompanies() {
    // this.auth.getCompaniesByPhone(this.email_value).subscribe(
    //   (next) => this.handleCompanies(next),
    //   (err) => this.alert(err.error)
    // );
  }

  handleCompanies(companies: Company[]) {
    this.companies = companies;
    if (companies.length > 1) {
      this.step = 2;
    } else if (companies.length === 1) {
      this.selectCompany(this.companies[0]);
    } else {
      this.alert(this.t('email not found'));
    }
  }

  // step-2
  selectCompany(company: Company) {
    // this.auth.sendOtpCode(company.code, phone).subscribe(
    //   (next) => {
    //     if (!next.token || !next.expires_in) {
    //       this.alert(this.t('token not found'));
    //       return;
    //     }
    //     this.otp = next;
    //     this.step = 3;
    //   },
    //   (err) => this.alert(err.error)
    // );
  }

  back() {
    this.clearAlert();
    if (this.step === 1) {
      this.router.navigate(['../']);
    } else if (this.step === 2) {
      this.companies = [];
      this.step--;
    } else if (this.step === 3) {
      this.otp = undefined;
      this.step--;
      if (this.companies.length === 1) {
        this.back();
      }
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
