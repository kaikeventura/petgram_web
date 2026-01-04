enum FriendshipStatusValue {
  none, // Não há relação
  sentRequest, // Eu enviei o pedido
  receivedRequest, // Eu recebi o pedido
  accepted, // Somos amigos
  blocked, // Bloqueado
  isMe, // É o meu próprio perfil
}

class FriendshipState {
  final FriendshipStatusValue status;
  // O ID do pet que enviou a solicitação, útil para aceitar o pedido.
  final String? pendingRequesterId;

  FriendshipState(this.status, {this.pendingRequesterId});
}
