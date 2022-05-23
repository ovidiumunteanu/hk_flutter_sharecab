class Userdetails {
  final String uid;
  final String name;
  final String email;
  final String mobilenum;
  final String hostel;
  final String sex;
  final int totalrides;
  final int cancelledrides;
  final int actualrating;
  final int numberofratings;

  final String currentGroup;
  final String device_token;
  final bool isAdmin;
  final bool isBlocked;

  Userdetails(
      {this.uid,
      this.name,
      this.email,
      this.mobilenum,
      this.currentGroup,
      this.device_token,
      this.isAdmin,
      this.isBlocked,
      this.hostel,
      this.sex,
      this.totalrides,
      this.cancelledrides,
      this.actualrating,
      this.numberofratings});
}
