enum FriendshipStatusValue {
  none, // Ninguém segue ninguém.
  pendingSent, // Eu enviei, ele ainda não aceitou.
  pendingReceived, // Ele enviou para mim, eu ainda não aceitei.
  following, // Eu sigo ele (e ele não me segue).
  followedBy, // Ele me segue, mas eu não o sigo.
  mutual, // Ambos se seguem.
  isMe, // É o meu próprio perfil
}

class FriendshipState {
  final FriendshipStatusValue status;
  // O ID do pet que enviou a solicitação, útil para aceitar o pedido.
  final String? pendingRequesterId;

  FriendshipState(this.status, {this.pendingRequesterId});
}
