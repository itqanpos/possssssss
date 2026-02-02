import { Request, Response, NextFunction } from 'express';
import * as admin from 'firebase-admin';
import * as jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

export interface AuthenticatedRequest extends Request {
  user?: {
    uid: string;
    email: string;
    role: string;
    companyId: string;
    branchId?: string;
    displayName?: string;
    permissions?: any[];
  };
}

export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const token = authHeader.substring(7);

    // Verify JWT token
    const decoded = jwt.verify(token, JWT_SECRET) as any;

    // Get user from Firebase Auth to verify token is still valid
    try {
      await admin.auth().getUser(decoded.uid);
    } catch (error) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }

    // Get user data from Firestore
    const userDoc = await admin.firestore().collection('users').doc(decoded.uid).get();
    const userData = userDoc.data();

    if (!userData || userData.status !== 'active') {
      return res.status(403).json({
        success: false,
        message: 'User account is not active'
      });
    }

    // Attach user to request
    (req as AuthenticatedRequest).user = {
      uid: decoded.uid,
      email: decoded.email,
      role: decoded.role,
      companyId: decoded.companyId,
      branchId: decoded.branchId,
      displayName: userData.displayName,
      permissions: userData.permissions || []
    };

    next();
  } catch (error: any) {
    console.error('Authentication error:', error);
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Authentication failed'
    });
  }
};

export const authorize = (resource: string, action: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as AuthenticatedRequest).user;

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Not authenticated'
      });
    }

    // Admin has full access
    if (user.role === 'admin') {
      return next();
    }

    // Check permissions
    const permissions = user.permissions || [];
    
    const hasPermission = permissions.some((perm: any) => {
      // Wildcard permission
      if (perm.resource === '*') {
        return perm.actions.includes(action) || perm.actions.includes('*');
      }
      
      // Specific resource permission
      if (perm.resource === resource) {
        return perm.actions.includes(action) || perm.actions.includes('*');
      }

      return false;
    });

    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        message: 'Insufficient permissions'
      });
    }

    next();
  };
};

// Role-based authorization
export const requireRole = (...allowedRoles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as AuthenticatedRequest).user;

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Not authenticated'
      });
    }

    if (!allowedRoles.includes(user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Insufficient role permissions'
      });
    }

    next();
  };
};

// Company ownership check
export const requireCompanyAccess = (paramName: string = 'companyId') => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as AuthenticatedRequest).user;
    const targetCompanyId = req.params[paramName] || req.body.companyId;

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Not authenticated'
      });
    }

    // Admin can access any company
    if (user.role === 'admin') {
      return next();
    }

    if (targetCompanyId && targetCompanyId !== user.companyId) {
      return res.status(403).json({
        success: false,
        message: 'Cannot access resources from other companies'
      });
    }

    next();
  };
};
