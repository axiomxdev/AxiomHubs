export interface Payload {
    userId: string;
    email: string;
    type: string;
    expiration: number;
}

export interface resetToken {
    email: string;
}