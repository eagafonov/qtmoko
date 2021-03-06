/****************************************************************************
**
** This file is part of the Qt Extended Opensource Package.
**
** Copyright (C) 2009 Trolltech ASA.
**
** Contact: Qt Extended Information (info@qtextended.org)
**
** This file may be used under the terms of the GNU General Public License
** version 2.0 as published by the Free Software Foundation and appearing
** in the file LICENSE.GPL included in the packaging of this file.
**
** Please review the following information to ensure GNU General Public
** Licensing requirements will be met:
**     http://www.fsf.org/licensing/licenses/info/GPLv2.html.
**
**
****************************************************************************/

#ifndef QPIMSOURCEDIALOG_H
#define QPIMSOURCEDIALOG_H

#include <QDialog>
#include <qtopiaglobal.h>

class QPimModel;
class QPimSourceModel;

class QPimSourceDialogData;
class QTOPIAPIM_EXPORT QPimSourceDialog : public QDialog
{
    Q_OBJECT
public:
    QPimSourceDialog(QWidget *parent = 0);
    ~QPimSourceDialog();

    virtual void setPimModel(QPimModel *);

    QPimSourceModel* pimSourceModel() const;

private:
    void accept();

    QPimSourceDialogData *d;
};
#endif
